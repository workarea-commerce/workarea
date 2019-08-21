class Mongoid::Criteria
  def except(id)
    where(:id.ne => id)
  end
end
