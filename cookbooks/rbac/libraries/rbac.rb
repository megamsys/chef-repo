module RBAC
  def self.authorizations
    @authorizations ||= {}
  end

  def self.add_authorization(username, auth)
    authorizations[username] ||= []
    authorizations[username] << auth
  end
end
