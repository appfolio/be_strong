module BeStrong
  class Code
    include Comparable

    REG_MASS_ASSIGNMENT_METHOD = /((new|build|build_.*|update|update!|assign_attributes|update_attributes|update_attributes!)([\( )])params\[:(\w*)\])/

    def initialize(code)
      @code     = code
      @original = code.dup
    end

    def apply_strong_parameter!
      # replace params[:model] to model_params
      models = []
      code.gsub!(REG_MASS_ASSIGNMENT_METHOD) do
        if StrongParameterMethods.method_for($4)
          models << $4
          "#{$2}#{$3}#{$4}_params"
        else
          $1
        end
      end

      return self if models.size.zero?

      # add private section
      add_private!

      # add model_params method as private method
      models.each do |model|
        method = StrongParameterMethods.method_for(model)
        next unless method

        next if code.include?("def #{model}_params")

        code.sub!(/^  private$/) do
          "  private\n\n#{method.gsub(/^/, '  ').chomp}"
        end
      end

      self
    end

    def add_private!
      unless code.include?('private')
        code.sub!(/^end/) do
          "\n  private\nend"
        end
      end
      self
    end

    def remove_attr_accessible_and_protected!
      %w(accessible protected).each do |name|
        code.gsub!(/( *attr_#{name}\(.*?\)$)/m, '')
        code.gsub!(/( *attr_#{name}.+?[^,\\]$)/m, '')
      end
      self
    end

    def changed?
      code != @original
    end

    def to_str
      code
    end

    def <=>(other)
      code <=> other
    end

    private

    def code
      @code
    end
  end
end
