# Article
# Simple model used for news about MO, e.g., new releases
# New articles are added to the Acitivity feed
#
# == Attributes
#
#  name::               headline
#  id::                 unique numerical id (starting at 1)
#  rss_log_id::         unique numerical id
#  created_at::         Date/time it was first created.
#  updated_at::         Date/time it was last updated.
#  user::               user who created article
#
# == methods
#  author::             user.name + user.login
#  display_name::       name boldfaced
#  format_name          name
#  unique_format_name   name + id
#  can_edit?            Can the user create, edit, or delete Articles?
#
class Article < AbstractModel
  belongs_to :user
  belongs_to :rss_log

  # Automatically log standard events.
  self.autolog_events = [:created_at!, :updated_at!, :destroyed!]

  # name boldfaced (in Textile). Used by show and index templates
  def display_name
    "**#{name}**"
  end

  # Article creator. Used by show and index templates
  def author
    "#{user.name} (#{user.login})"
  end

  # used by MatrixBoxPresenter to show orphaned obects
  def format_name
    name
  end

  # title + id
  # used by MatrixBoxPresenter to show unorphaned obects
  def unique_format_name
    name + " (#{id || "?"})"
  end

  # wrapper around class method of same name
  def can_edit?(user)
    Article.can_edit?(user)
  end

  # Can the user create, edit, or delete Articles?
  def self.can_edit?(user)
    news_article_project.is_member?(user)
  end

  # Project used to administer Article write permission.
  # User of this project may create, edit, or delete Articles.
  def self.news_article_project
    Project.find_by(title: "News Article Project")
  end
end
