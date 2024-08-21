require_dependency 'issue'

module RedmineIssueChecklist
  module Patches
    module IssuePatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          has_many :checklist, class_name: 'IssueChecklist', dependent: :destroy
          alias_method :copy_from, :checklist
        end
      end

      module InstanceMethods
        def copy_from_with_checklist(arg, options={})
          copy_from_without_checklist(arg, options)
          issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
          self.checklist = issue.checklist.map { |cl| cl.dup }
          self.checklist.each { |object| object.is_done = nil }
          self
        end

        def update_checklist_items(checklist_items, create_journal = false)
          checklist_items ||= []
          old_checklist = checklist.collect(&:info).join(', ')
          checklist.destroy_all
          checklist << checklist_items.uniq.collect do |cli|
            IssueChecklist.new(is_done: cli[:is_done], subject: cli[:subject])
          end
          new_checklist = checklist.collect(&:info).join(', ')
          if current_journal && create_journal && (new_checklist != old_checklist)
            current_journal.details << JournalDetail.new(
              property:  'attr',
              prop_key:  'checklist',
              old_value: old_checklist,
              value:     new_checklist)
          end
        end
      end

    end
  end
end

unless Issue.included_modules.include?(RedmineIssueChecklist::Patches::IssuePatch)
  Issue.send(:include, RedmineIssueChecklist::Patches::IssuePatch)
end
