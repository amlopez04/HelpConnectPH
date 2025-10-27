class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @report.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      # Send email notification to report creator
      ReportMailer.new_comment_notification(@report, @comment).deliver_now
      redirect_to @report, notice: "Comment was successfully added."
    else
      redirect_to @report, alert: "Failed to add comment: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    authorize @comment
    @comment.destroy
    redirect_to @report, notice: "Comment was successfully deleted."
  end

  private

  def set_report
    @report = Report.find(params[:report_id])
  end

  def set_comment
    @comment = @report.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
