class ProjectList < LifeList
  belongs_to :project
  validates_presence_of :project_id
  
  def owner
    project
  end
  
  def owner_name
    project.title
  end
  
  def listed_taxa_editable_by?(user)
    return false if user.blank?
    project.project_users.exists?(:user_id => user)
  end
  
  def refresh(options = {})
    # ProjectLists listed taxa *must* be observed
    super(options.merge(:destroy_unobserved => true))
  end
  
  def first_observation_of(taxon)
    return nil unless taxon
    project.observations.recently_added.of(taxon).last
  end
  
  def last_observation_of(taxon)
    return nil unless taxon
    project.observations.of(taxon).latest.first
  end
  
  def observation_stats_for(taxon)
    project.observations.of(taxon).count(:group => "EXTRACT(month FROM observed_on)")
  end
  
  
  private
  def set_defaults
    self.title ||= "%s's Check List" % owner_name
    self.description ||= "Every species observed by members of #{owner_name}"
    true
  end
end
