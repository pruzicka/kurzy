class EnrollmentPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
