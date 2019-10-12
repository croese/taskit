module Taskit
  class Task
    attr_reader :description, :created, :priority, :completion_date, :contexts, :projects

    def initialize(description, created: nil, priority: nil)
      raise ArgumentError, "Description must be provided" unless description
      self.description = description
      self.created = created

      if priority && !(/^[A-Z]$/.match? priority.to_s)
        raise InvalidPriorityError,
              "Invalid priority #{priority}. Task priority must be a letter in A-Z"
      end

      self.priority = priority
      self.contexts = extract_contexts
      self.projects = extract_projects
    end

    def complete(date)
      raise ArgumentError, "Completion date may not be nil" unless date
      self.completion_date = date
    end

    def completed?
      completion_date
    end

    def to_s
      created_str = if created then
                      "#{created} "
                    else
                      ''
                    end
      priority_str = if priority then
                       "(#{priority}) "
                     else
                       ''
                     end
      completion_str = if completed? then
                         "x #{completion_date} "
                       else
                         ''
                       end

      "#{completion_str}#{priority_str}#{created_str}#{description}"
    end

    private

    attr_writer :description, :created, :priority, :completion_date, :contexts, :projects

    def extract_contexts
      Set.new(description.scan(/ @(\S+)/).flatten.map { |s| s.downcase })
    end

    def extract_projects
      Set.new(description.scan(/ \+(\S+)/).flatten.map { |s| s.downcase })
    end
  end
end
