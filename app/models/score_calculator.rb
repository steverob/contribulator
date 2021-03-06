class ScoreCalculator
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def score
    [
      fork? ? 0 : 1,
      description_present? ? 1 : 0,
      homepage_present? ? 1 : 0,
      readme_present? ? 5 : 0,
      contributing_present? ? 5 : 0,
      license_present? ? 5 : 0,
      changelog_present? ? 1 : 0,
      tests_present? ? 5 : 0,
      open_issues_created_since(6.months) > 10 ? 5 : 0,
      commits_since(6.months) > 10 ? 5 : 0,
      has_issues? ? 5 : 0
    ].sum
  end

  def summary
    {
      fork: fork?,
      description_present: description_present?,
      homepage_present: homepage_present?,
      readme_present: readme_present?,
      contributing_present: contributing_present?,
      license_present: license_present?,
      changelog_present: changelog_present?,
      tests_present: tests_present?,
      open_issues_last_6_months: open_issues_created_since(6.months),
      master_commits_last_6_months: commits_since(6.months),
      has_issues: has_issues?
    }
  end

  private

  def fork?
    project.fork?
  end

  def description_present?
    project.description.present?
  end

  def homepage_present?
    project.homepage.present?
  end

  def readme_present?
    file_exists?('readme')
  end

  def contributing_present?
    file_exists?('contributing')
  end

  def license_present?
    file_exists?('license')
  end

  def changelog_present?
    file_exists?('change')
  end

  def tests_present?
    folder_exists?('test') || folder_exists?('spec')
  end

  def has_issues?
    project.has_issues?
  end

  def open_issues_created_since(date)
    date_since = (Date.today - date).to_time.iso8601
    github_client.list_issues(project.repo_id).count
  end

  def commits_since(date)
    date_since = (Date.today - date).to_time.iso8601
    github_client.commits(project.repo_id).count
  end

  def github_client
    project.github_client
  end

  def ls
    @ls ||= github_client.contents(project.repo_id, path: '/')
  end

  def files
    ls.select { |f| f[:type] == 'file' }.map { |f| f[:path] }
  end

  def folders
    ls.select { |f| f[:type] == 'dir' }.map { |f| f[:path] }
  end

  def file_exists?(name)
    files.find { |f| f.match(/#{name}/i) }.present?
  end

  def folder_exists?(name)
    folders.find { |f| f.match(/#{name}/i) }.present?
  end
end
