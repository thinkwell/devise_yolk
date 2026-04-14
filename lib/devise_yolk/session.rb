module DeviseYolk

  # Similar to warden.session, but allows saving information before
  # the user is fully authenticated
  def self.session(manager, scope=nil)
    scope = manager.default_scope unless scope
    manager.raw_session["warden.user.#{scope}.yolk"] ||= {}
  end

  def self.remove_session(manager, scope=nil)
    scope = manager.default_scope unless scope
    manager.raw_session.delete("warden.user.#{scope}.yolk")
  end

end
