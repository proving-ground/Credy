require 'yaml'

module Credy

  class Rules

    # Return all the rules from yml files
    def self.all
      @rules ||= begin
        rules = {}
        Dir.glob "#{Credy.root}/data/*.yml" do |filename|
          r = YAML::load IO.read(filename)
          rules.merge! r
        end
        rules
      end
    end

    # Change hash format to process rules
    def self.flatten(global_rules = false)
      rules = []

      all.each do |type, details|
        
        if global_rules
          # Add general rules
          global_prefixes = details['prefix']
          if global_prefixes
            global_prefixes = [global_prefixes] unless global_prefixes.is_a? Array

            global_prefixes.each do |prefix|
              rules.push({
                prefix: prefix.to_s,
                length: details['length'],
                type: type
              })
            end
          end
        end

        # Process each country
        if details['countries']
          details['countries'].each do |country, prefixes|
            prefixes = [prefixes] unless prefixes.is_a? Array

            # Add a rule for each prefix
            prefixes.each do |prefix|
              rules.push({
                prefix: prefix.to_s,
                length: details['length'],
                type: type,
                country: country,
              })
            end
          end
        end

      end

      # Sort rules by prefix length
      rules.sort! { |x, y|  y[:prefix].length <=> x[:prefix].length }

      rules
    end

    # Returns rules according to given filters
    def self.filter(filters = {}, global_rules = false)
      flatten(global_rules).select do |rule|
        [:length, :country, :type].each do |condition|
          break false if filters[condition] && filters[condition] != rule[condition]
          true
        end
      end
    end

  end

end
