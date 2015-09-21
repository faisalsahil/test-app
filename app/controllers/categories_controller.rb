class CategoriesController < ApplicationController
	respond_to :html, :json, only: [:index,:questions,:question]
	def index
		choice = Choice.where(checklist_id: params[:report]).first
		if choice.present?
			@category = Category.where(id: choice.category_id)
		else
			@category = Category.all
		end
		respond_with :obj => { category: @category}
	end

	def answers
		@report = Report.find(params[:report_id])
		@category = Category.find(params[:id])
	end

	def questions
		@category = Category.find(params[:id])
		@questions = @category.questions
		respond_with @questions
	end

	def question
		@status = false
		@category = Category.find(params[:id])
		@question = @category.questions.first
		choice = Choice.where(checklist_id: params[:report]).first

		@noanswer = false
		qids = @category.questions.pluck(:id)
		answers = Answer.where(report_id: params[:report], question_id: qids, status: 2)
		if answers.count > 0
			@noanswer = true
		end

		if !choice.present?
			choice = Choice.new
			choice.checklist_id = params[:report]
			choice.category_id = @category.id
			choice.save!
		else
			@status = true
		end
		@answer = Answer.where(question_id: @question.id, report_id: params[:report]).first
	end

	def no_questions
		@category = Category.find(params[:id])
		# choice = Choice.where(checklist_id: params[:report]).first
		q_ids = []
		@category.questions.each do |q|
			ans = q.answers.find_by(report_id: params[:report])
			if ans.status == 2
				q_ids << q.id
			end
		end
		questions = Question.where(id: q_ids)
		return render :json=> questions
	end
end
