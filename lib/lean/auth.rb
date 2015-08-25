
class Lean::Auth
  include Singleton

  attr_reader :user
  attr_reader :logged_in

  def initialize
    @logged_in = false

    cleanup_expired

    cookies = Lean::Request.cookies

    if (cookies['auth'] and (session = Lean::Session.where(:session_id => cookies['auth'], :ip_address => Lean::Request.ip, :user_agent => Lean::Request.user_agent).first))
      if (@user = Lean::User.get(session.user_id))
        @logged_in = true
        session.save
      else
        session.delete
      end
    end
  end

  def self.respond_to?(method, include_private = false)
    self.instance.respond_to? method, include_private
  end

  def self.method_missing method, *args, &block
    self.instance.send method, *args, &block
  end

  def login(username, password, force=false)
    if (user = Lean::DB.con[:user].where(:username => username, :active => 1).first)
      user = Lean::User.hydrate(user)
      if force || Digest::SHA1.hexdigest("#{user.salt}#{password}") == user.password
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
      end
    end

    false
  end

  def cleanup_expired
    Lean::Session.where('expiry <= ?',Time.now).delete
  end

  def logout
    Lean::Session.where('session_id = ?',Lean::Request.cookies['auth']).delete
  end
end
