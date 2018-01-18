RSpec::Matchers.define  :be_a_valid_availabilities_history do
  match do |availability_history|
    availability_history.each do |provider|
      provider['endpoints_availability_history'].each do |ep|
        max_index = ep['availability_history'].size - 1
        index = 0
        previous_to_time = nil

        ep['availability_history'].each do |avail|
          if index < max_index
            # from < to (except for last one)
            expect(Time.parse(avail[0])).to be < Time.parse(avail[2])
            index += 1
          end

          # has no gap
          unless previous_to_time.nil?
            from_time = Time.parse(avail[0])
            expect(from_time).to eq(previous_to_time)
          end

          previous_to_time = Time.parse(avail[2])
        end
      end
    end
  end
end

RSpec::Matchers.define :be_a_valid_availability_history do
  match do |availability_history|
    previous_to_time = nil
    availability_history.to_a.each do |a|
      # from < to
      expect(Time.parse(a[0])).to be < Time.parse(a[2])

      # has no gap
      unless previous_to_time.nil?
        from_time = Time.parse(a[0])
        expect(from_time).to eq(previous_to_time)
      end

      previous_to_time = Time.parse(a[2])
    end
  end
end