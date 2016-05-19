# Encodings for popup
#
def encodingHash
  encodings = {
    "" => "EQ31 (Default)",
    "NAEQ" => "New Aeon English Qabalah (NAEQ)",
    "LQS" => "Latin Qabalah Simplex (LQS)",
  }
end

# Generate the popup
#
def getEncodingPopup(l)

  # Get encoding list
  enc = encodingHash

  # The generated popup
  output = "<select id=\"geml\" name=\"l\">\n"

  # Loop through and build
  #
  enc.keys.each do |e|
    output += "<option value=\"#{e}\"";
    if (e == l)
      output += " selected"
    end
    output += ">#{enc[e]}</option>\n";
  end

  # Close popup and return
  output += "</select>\n";

end

