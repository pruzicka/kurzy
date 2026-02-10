class EnrollmentMailer < ApplicationMailer
  def course_granted(enrollment)
    @enrollment = enrollment
    @user = enrollment.user
    @course = enrollment.course

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Máte přístup ke kurzu: #{@course.name}"
    )
  end

  def course_revoked(enrollment)
    @enrollment = enrollment
    @user = enrollment.user
    @course = enrollment.course

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Přístup ke kurzu odebrán: #{@course.name}"
    )
  end
end
