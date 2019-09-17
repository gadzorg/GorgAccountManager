And(/^([a-zA-Z]+) has a Soce Account with ((?:[a-zA-Z_]+ ["'][^"']*["'](?:, )?)*)$/) do |firstname,raw_attrs|

  @soce_id||=84189

  attrs=raw_attrs.split(",").map do |e|
    match=/([a-zA-Z_]+) "([^"]*)"/.match(e)
    [match[1],match[2]]
  end.to_h

  create(:soce_user, { id_user: @soce_id, prenom: firstname }.merge(attrs))
end
