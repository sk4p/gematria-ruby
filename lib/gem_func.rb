# -*- coding: utf-8 -*- connect to the database
#

# Additional hash methods
#
class Hash

  # Output this nicely
  #
  def output(n)
    o = self['string'].quote(self['encoding'])
    o += "<br>\n"
    if (self['encoding'] > 0)
      o += "<em>#{self['definition']}</em>\n"
    end
    o = o.entryLink(self['id'])

    # Secondary values
    #
    if (n == self['secondary']) 
      secmsg = {
        3=>'(with Hebrew final values)',
        4=>'(with ΣΤ as separate letters)',
      }
      o += "<em>#{secmsg[self['encoding']]}</em>"
    end

    "#{o}"
  end

end

# Additional array methods
#
class Array

  # Output this nicely
  #
  def output(n)
    o = ''
    self.each do |e|
      # Each of these is an entry, and thus a hash. Output it nicely.
      o += "#{e.output(n)}".tag('div','gemhit')
    end
    o
  end

end

# Additional integer methods
#
class Integer

  # Wrap this number in a link to a number.
  #
  def numberLink(n)
    self.to_s.numberLink(n)
  end

  # Produce an entry row from an integer
  # (given title)
  #
  def entryRow(h)
    self.to_s.entryRow(h)
  end

  # Show an entry given its ID
  #
  def showEntry
    
    # query
    rs = $db.query("select * from gematria " \
                   + "where id = #{self}")

    # show the results
    #
    output = '<table id="gementry">'
    rs.each do |row|

      # Encode the title nicely
      output += "<tr><th class=\"gemtablehead\" colspan=\"2\">#{row['string'].quote(row['encoding'])}</th></tr>\n"

      # Value
      output += row['value'].numberLink(row['value']).entryRow('Value')

      # Secondary value
      #
      if (row['secondary'] != nil)
        secmsg = {
          3=>'Hebrew finals value',
          4=>'ΣΤ as two letters value',
        }
        output += row['secondary'].numberLink(row['secondary']).entryRow(secmsg[row['encoding']])

      end

      # Definition
      #
      if (row['definition'] != nil)
        output += row['definition'].entryRow('Definition')
      end

      # Note
      #
      if (row['note'] != nil)
        note = row['note']
        note.gsub("\n","<br>")
        output += note.entryRow('Note')
      end

      # Citation
      #
      if (row['citation'] != nil)
        output += row['citation'].entryRow('Source')
      end

      # Strong's Concordance
      #
      if (row['strongs'] != nil)
        if (row['encoding'] == 3)
          lang = "hebrew"
        else
          lang = "greek"
        end
        link = "<a target=\"_blank\" href=\"http://biblehub.com/#{lang}/#{row['strongs']}.htm\">"
        link += row['strongs'] + lang.capitalize[0] + "</a>"
        output += link.entryRow('Strong\'s ID#')
      end

      # And our entry ID
      output += row['id'].entryRow('Entry ID#')

      output += "</table>\n"
    end

    # And output it
    output
  end

  # Return array of entries at this value
  #
  def lookup
    rs = $db.query("select * from gematria " \
                   + "where value = #{self} " \
                   + "or secondary = #{self}")
    a = Array.new
    rs.each do |r|
      a.push(r)
    end
    a
  end

  # Do gematria for a number
  #
  def doGematriaNumber
    output = "Entries having the value #{self}:".tag('p','gemhead')
    output += self.lookup.output(self)
    output
  end

end

# Additional string methods
#
class String

  # Do gematria for a number
  #
  def doGematriaNumber
    self.to_i.doGematriaNumber
  end

  # Is this string to be considered a string or number?  If it's greater
  # than zero and has no letters, it's a number.
  #
  def is_num?
    if ((self.to_i > 0) && (self.index(/\D/) == nil))
      true
    else
      false
    end
  end
  
  # Convert Greek stigmas into digammas.
  #
  def stigma
    r = {"\xCE\xA3\xCE\xA4" => "\xCF\x9C", # ST
      "\xCE\xA3\xCF\x84" => "\xCF\x9C", # St
      "\xCF\x83\xCE\xA4" => "\xCF\x9C", # sT
      "\xCF\x83\xCF\x84" => "\xCF\x9C"} # st
    stigma = self
    r.each do |b,a|
      stigma = stigma.gsub(b,a)
    end
    stigma
  end

  # Get the gematric value of this string, given hash of options.
  #
  def getValue(h)
    enc = getMainEncoding()

    # Use NAEQ?
    if (h.has_key?('naeq'))
      enc = getNAEQ(enc)
    end

    # Get Hb finals?
    if (h.has_key?('finals'))
      enc = getFinals(enc)
    end

    # Expand stigmas to sigma + tau?
    if (h.has_key?('stexpand'))
      s = self
    else
      s = self.stigma
    end

    n = 0
    s.split(//u).each do |c|
      if (enc.has_key?(c.ord))
        n += enc[c.ord]
      end
    end
    n
  end

  # Wrap this string in a link to an entry.
  #
  def entryLink(e)
    "<a href=\"/gematria/?e=#{e}\">#{self}</a>"
  end

  # Wrap this string in a link to a number.
  #
  def numberLink(n)
    "<a href=\"/gematria/?s=#{n}\">#{self}</a>"
  end

  # Print this string in the correct quotes.
  #
  def quote(e)
    e = e.to_i
    # Quotes for each encoding: left, right
    quotes = [
              ['<em>','</em>'], # text item
              ['&ldquo;','&rdquo;'], # eq31 / default
              ['&ldquo;','&rdquo; (NAEQ)'], # naeq
              ['',''], # hebrew
              ['&laquo;','&raquo;'], # greek
             ]
    # And return
    "#{quotes[e][0]}#{self}#{quotes[e][1]}"
  end

  # Wrap this string in tags; optional class
  #
  def tag(t,c='')
    if (c != '')
      c = " class=\"#{c}\""
    end
    "<#{t}#{c}>#{self}</#{t}>\n"
  end

  # Produce an entry row from a string
  # (given title)
  #
  def entryRow(h)
    "<tr><th>#{h}</th><td>#{self}</td></tr>\n"
  end

  # Do gematria for a string
  #
  def doGematriaString(l)

    # Value options hash
    vo = Hash.new

    # Using NAEQ?
    #
    if (l == 'NAEQ')
      vo['naeq'] = 1
    end

    # Get value and show it
    #
    n = self.getValue(vo)
    output = "The value of the string &ldquo; #{s} &rdquo; is #{n}:".tag('p','gemhead')
    output += n.lookup.output(n)

    # Finals?
    #
    vo['finals'] = 1
    nf = self.getValue(vo)
    if (nf != n) 
      output += "The value using Hebrew final letter values is #{nf}:".tag('p','gemhead')
      output += nf.lookup.output(nf)
    end
    
    # ST expanded?
    #
    vo.delete('finals')
    vo['stexpand'] = 1
    ns = self.getValue(vo)
    if (ns != n)
      output += "The value counting ΣΤ as separate letters is #{ns}:".tag('p','gemhead')
      output += ns.lookup.output(ns)
      vo['finals'] = 1
      nsf = self.getValue(vo)
      if (nsf != ns)
        output += "The value counting ΣΤ as separate letters <em>and</em> using Hebrew final letter values is #{nsf}:".tag('p','gemhead')
        output += nsf.lookup.output(nsf)
      end
    end

    output

  end

  # Do gematria for input
  #
  def doGematria(l)

    # Our output
    output = ''

    # Sanitize and strip whitespace. Then return if empty.
    #
    s = Sanitize.fragment(self)
    s = s.strip
    if (s == '')
      return
    end

    # First off, do we have anything to process?
    #
    if (s.is_num?)
      # It's a number! Look it up and spit out the results.
      output = s.doGematriaNumber
    else
      # It's really a string.  Calculate its values and all that fun.
      output = s.doGematriaString(l)
    end

  end
end
