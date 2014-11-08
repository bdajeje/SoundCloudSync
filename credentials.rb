class Credentials

  def initialize(credential_filepath)
    # Read credentials file
    content = File.open(credential_filepath).read
    lines = content.split("\n")
    raise "Wrong credentials file '#{credential_filepath}'" if lines.empty?

    @client_id = lines[0]
  end

  attr_reader :client_id

end
