class UserPolicy < ApplicationPolicy
  def access_member?
    user.present?
  end

  def access_admin?
    !!(user&.staff? || user&.admin?)
  end

  def manage_staff?
    !!user&.admin?
  end

  def manage_admins?
    !!user&.admin?
  end

  def demote_self?
    user != record
  end
end
