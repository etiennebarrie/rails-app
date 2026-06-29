# Minimal controller (inherits ActionController::Base directly, skipping the
# ApplicationController callbacks) so the request-cycle benchmark isolates the
# routing -> controller -> format-negotiation -> render path and surfaces any
# Mime registry access cost. See tmp/bench_mime.rb.
class BenchController < ActionController::Base
  # Baseline: no template, no negotiation. Floor for "what does a request cost".
  def plain
    render plain: "ok"
  end

  # Template render: exercises LookupContext format resolution (which reads the
  # Mime registry) plus a partial lookup.
  def template
    render layout: false
  end

  # The respond_to content-negotiation path the PR description calls out.
  def negotiate
    respond_to do |format|
      format.html { render plain: "html" }
      format.text { render plain: "plain" }
    end
  end

  # respond_to where one branch is JSON, to cover the other common shape.
  def json_negotiate
    respond_to do |format|
      format.html { render plain: "html" }
      format.json { render json: { ok: true } }
    end
  end
end
