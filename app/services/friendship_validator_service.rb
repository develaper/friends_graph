class FriendshipValidatorService

  def initializer()
  end

  def one_degree_of_separation?(current_user, target_user)
    check_degrees_of_separation(1, current_user, target_user)
  end

  def two_degrees_of_separation?(current_user, target_user)
    check_degrees_of_separation(2, current_user, target_user)
  end

  def check_degrees_of_separation(degrees = 1, current_user, target_user)
    current_user.friends(rel_length: degrees + 1).where(id:target_user.id).any?
  end
end
