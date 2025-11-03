class NormalizePhoneNumbersAndUniqueIndexOnUsers < ActiveRecord::Migration[7.1]
  # Minimal AR model to avoid app dependencies during migration
  class MigrationUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  def up
    # Drop existing unique index (if present) to allow temporary duplicates during normalization
    if index_exists?(:users, :phone_number, name: 'index_users_on_phone_number')
      remove_index :users, name: 'index_users_on_phone_number'
    end

    say_with_time 'Normalizing existing phone numbers to +63 format' do
      MigrationUser.reset_column_information
      MigrationUser.where.not(phone_number: [ nil, '' ]).find_each do |u|
        normalized = normalize(u.phone_number)
        next if normalized.blank?
        # Use update_columns to skip validations/callbacks
        u.update_columns(phone_number: normalized) if u.phone_number != normalized
      end
    end

    # De-duplicate numbers by keeping the earliest user id and nulling the rest
    say_with_time 'De-duplicating normalized phone numbers' do
      dup_numbers = MigrationUser.where.not(phone_number: [ nil, '' ])
                                 .group(:phone_number)
                                 .having('COUNT(*) > 1')
                                 .pluck(:phone_number)

      dup_numbers.each do |num|
        ids = MigrationUser.where(phone_number: num).order(:id).pluck(:id)
        keep_id = ids.shift
        next if ids.empty?
        MigrationUser.where(id: ids).update_all(phone_number: nil)
      end
    end

    # Add unique index (ignore NULLs)
    add_index :users, :phone_number, unique: true, where: "phone_number IS NOT NULL", name: 'index_users_on_phone_number'
  end

  def down
    remove_index :users, name: 'index_users_on_phone_number' if index_exists?(:users, :phone_number, name: 'index_users_on_phone_number')
  end

  private

  def normalize(raw)
    return nil if raw.nil?
    value = raw.to_s.strip.gsub(/[^\d+]/, '')
    return "+63" + value[1..] if value.match?(/^09\d{9}$/)
    return "+" + value if value.match?(/^639\d{9}$/)
    return value if value.match?(/^\+639\d{9}$/)
    value
  end
end
