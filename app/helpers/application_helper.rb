module ApplicationHelper
  # Generate a secure random password with alphanumeric characters and symbols
  # Length: 8 characters
  def self.generate_secure_password
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9'), ['!', '@', '#', '$', '%', '^', '&', '*']].flatten
    (0...8).map { chars[rand(chars.length)] }.join
  end
end
