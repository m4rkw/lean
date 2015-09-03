
class Lean::Auth
  include Singleton

  attr_reader :user

  def logged_in
    if !@logged_in.nil?
      Lean::Log.add("notice","Cached value for logged in state: #{@logged_in.inspect}")
      return @logged_in
    end

    @logged_in = false

    Lean::Log.add("notice","Initialising authentication system")

    cleanup_expired

    cookies = Lean::Request.cookies

    if (cookies['auth'] and cookies['auth'].length >0)
      Lean::Log.add("notice","User has session key #{cookies['auth']}")
      if (session = Lean::Session.where(:session_id => cookies['auth'], :ip_address => Lean::Request.ip, :user_agent => Lean::Request.user_agent).first)
        Lean::Log.add("notice","Found database session #{cookies['auth']}")

        if (@user = Lean::User.get(session.user_id))
          Lean::Log.add("notice","Found user for session: #{@user.username}, logged in")
          @logged_in = true
          session.save
        else
          Lean::Log.add("notice","No user for session, deleting")
          session.delete
        end
      else
        Lean::Log.add("notice","Session not found in database")
      end
    else
      Lean::Log.add("notice","User has no session key")
    end

    @logged_in
  end

  def self.respond_to?(method, include_private = false)
    self.instance.respond_to? method, include_private
  end

  def self.method_missing method, *args, &block
    self.instance.send method, *args, &block
  end

  def login(username, password, force=false)
    Lean::Log.add("notice","Attempting login as #{username}")

    if (user = Lean::DB.con[:user].where(:username => username, :active => 1).first)
      Lean::Log.add("notice","User #{username} found and active")

      user = Lean::User.hydrate(user)
      if force || Digest::SHA1.hexdigest("#{user.salt}#{password}") == user.password
        Lean::Log.add("notice","Password accepted for user #{username}")
        session = Lean::Session.new
        session.user_id = user.id
        session.ip_address = Lean::Request.ip
        session.user_agent = Lean::Request.user_agent

        session.save

        Lean::Cookie.set('auth', {
          :value => session.session_id,
          :path => '/',
          :expires => Time.now + Lean::Config.get(:session_expiry)
        })

        return true
      else
        Lean::Log.add("notice","Password incorrect for user #{username}")
      end
    else
      Lean::Log.add("notice","User #{username} not found")
    end

    false
  end

  def cleanup_expired
    Lean::Session.where('expiry <= ?',Time.now).delete
  end

  def logout
    Lean::Log.add('notice',"Logout, nuking session #{Lean::Request.cookies['auth']}")

    Lean::Session.where('session_id = ?',Lean::Request.cookies['auth']).delete

    Lean::Cookie.set('auth', {
      :value => '',
      :path => '/',
      :expires => Time.now + Lean::Config.get(:session_expiry)
    })
  end
end
