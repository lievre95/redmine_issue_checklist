require 'redmine'
require_relative 'hooks/model_issue_hook'
require_relative 'hooks/views_issues_hook'

Rails.configuration.to_prepare do
  require_relative 'patches/issue_patch'
  require_relative 'patches/issues_controller_patch'
end

module RedmineIssueChecklist
  class RedmineIssueChecklist
    def self.settings()
      Setting[:plugin_redmine_issue_checklist].blank? ? {} : Setting[:plugin_redmine_issue_checklist]
    end
  end
end

