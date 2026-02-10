class OauthIdentityPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
