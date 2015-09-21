json.reports do |json|
	json.array!(@reports) do |json,report|
	  json.id report.id
	  json.name report.name
	  @answers = report.answers.where(status: 2).count
	  choice = Choice.where(checklist_id: report.id).first
	    if choice.present?
			@cat_names = Category.find(choice.category_id).name
	    else
			@cat_names = "Not selected"
		end
	  json.user_id @answers
	  json.catname @cat_names
	end
end


json.goodreports do |json|
	json.array!(@good_report) do |json,report|
	  json.id report.id
	  json.name report.name
	end
end
