require 'etc'
require 'tmpdir'
require 'puppet/file_serving/content'

Puppet::Type.type(:gnupg_key).provide(:gnupg) do

  @doc = 'Provider for gnupg_key type.'

  defaultfor :kernel => 'Linux'
  confine :kernel => 'Linux'

  def self.instances
    []
  end

  # although we do not use the commands class it's used to detect if the gpg command is installed on the system
  commands :gpg => 'gpg'

  def gpg_arg_trusted_keyring
    return resource[:trusted] ? '--no-default-keyring --keyring trustedkeys.gpg' : ''
  end

  def remove_public_key
    command = "gpg --batch --yes --delete-keys #{gpg_arg_trusted_keyring} #{resource[:key_id]}"
    begin
      output = Puppet::Util::Execution.execute(command,  :uid => user_id)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Could not remove #{resource[:key_id]} for user #{resource[:user]}: #{output}"
    end
  end

  # where most of the magic happens
  # TODO implement dry-run to check if the key_id match the content of the file
  def add_public_key
    if ! resource[:key_server].nil?
      command = "gpg #{gpg_arg_trusted_keyring} --keyserver #{resource[:key_server]} --recv-keys #{resource[:key_id]}"
      begin
        output = Puppet::Util::Execution.execute(command,  :uid => user_id, :failonfail => true)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "Key #{resource[:key_id]} does not exsist on #{resource[:key_server]}"
      end

    elsif ! resource[:key_source].nil?
      if Puppet::Util.absolute_path?(resource[:key_source])
        if File.file?(resource[:key_source])
          command = "gpg #{gpg_arg_trusted_keyring} --import #{resource[:key_source]}"
          begin
            output = Puppet::Util::Execution.execute(command, :uid => user_id, :failonfail => true)
          rescue Puppet::ExecutionFailure => e
            raise Puppet::Error, "Error while importing key #{resource[:key_id]} from #{resource[:key_source]}"
          end
        elsif
          raise Puppet::Error, "Local file #{resource[:key_source]} for #{resource[:key_id]} does not exists"
        end
      else
        uri = URI.parse(URI.escape(resource[:key_source]))
        case uri.scheme
          when /https/
            command = "wget -O- #{resource[:key_source]} | gpg #{gpg_arg_trusted_keyring} --import"
          when /http/
            command = "gpg #{gpg_arg_trusted_keyring} --fetch-keys #{resource[:key_source]}"
          when 'puppet'
            Puppet::Util::SUIDManager.asuser(user_id) do
              tmpfile = Tempfile.open(['golja-gnupg', 'key'])
              tmpfile.write(puppet_content)
              tmpfile.flush
              command = "gpg #{gpg_arg_trusted_keyring} --import #{tmpfile.path.to_s}"
            end
        end
        begin
          output = Puppet::Util::Execution.execute(command, :uid => user_id, :failonfail => true)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "Error while importing key #{resource[:key_id]} from #{resource[:key_source]}:\n#{output}}"
        end
      end
    end
  end

  def user_id
    begin
      Etc.getpwnam(resource[:user]).uid
    rescue => e
      raise Puppet::Error, "User #{resource[:user]} does not exists"
    end
  end

  def puppet_content
    # Look up (if necessary) and return remote content.
    return @content if @content
    unless tmp = Puppet::FileServing::Content.indirection.find(resource[:key_source], :environment => resource.catalog.environment, :links => :follow)
      fail "Could not find any content at %s" % resource[:key_source]
    end
    @content = tmp.content
  end

  def exists?
    command = "gpg #{gpg_arg_trusted_keyring} --list-keys --with-colons #{resource[:key_id]}"
    output = Puppet::Util::Execution.execute(command, :uid => user_id)
    if output.exitstatus == 0
      return true
    elsif output.exitstatus == 2
      return false
    else
      raise Puppet::Error, "Non recognized exit status from GnuPG #{output.exitstatus} #{output}"
    end
  end

  def create
    add_public_key()
  end

  def destroy
    remove_public_key()
  end
end
