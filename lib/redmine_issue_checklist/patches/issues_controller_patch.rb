module RedmineIssueChecklist
  module Patches
    module IssuesControllerPatch
      extend ActiveSupport::Concern

      included do
        if instance_methods.include?(:build_new_issue_from_params)
          alias_method :build_new_issue_from_params_without_checklist, :build_new_issue_from_params
          alias_method :build_new_issue_from_params, :build_new_issue_from_params_with_checklist
          def build_new_issue_from_params
            build_new_issue_from_params_without_checklist
            if User.current.allowed_to?(:edit_checklists, @issue.project)
              @issue.update_checklist_items(params[:check_list_items])
            end
          end
        else
          Rails.logger.error "The method 'build_new_issue_from_params' does not exist in IssuesController."
        end
      end
    end
  end
end

# Apply the patch to the IssuesController
unless IssuesController.included_modules.include?(RedmineIssueChecklist::Patches::IssuesControllerPatch)
  IssuesController.send :include, RedmineIssueChecklist::Patches::IssuesControllerPatch
end
