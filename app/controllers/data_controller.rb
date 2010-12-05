class DataController < ApplicationController
  
  def revisions
    render :json => Marginalia.history(params[:id],params[:size])
  end

  # returns an array of diffs of the last 500 revs of an article
  def diff
  	respond_in_format Marginalia.diff(params[:id])
  end

  # a count of unique author names for an article
  def author_count
    revisions = Marginalia.revisions(params[:id])
    authors = []
    revisions.collect {|rev| authors << rev['user']}
    authors.uniq!
    render :text => authors.length
  end

  # returns a nested array of authors of the last 500 revs of an article
  # and how many revs they each did, sorted descending
  def authors
	#params[:diff] = params[:diff].eql?"true"
  	respond_in_format Marginalia.authors(params[:id],params[:diff])
  end

  def author_location
  	render :text => Marginalia.author_location(params[:id])
  end

end
