class SearchLogger

  def log(query,type)
    Search.create(
        term: query,
        term_type: "type"
    )
  end

end