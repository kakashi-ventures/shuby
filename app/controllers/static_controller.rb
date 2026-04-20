class StaticController < ApplicationController
  def index
  end

  def app_preview
    @preview_activities = ArchiveContent.published.activities.ordered.limit(2)
  end

  def about
  end

  def terms
    @agreement = Rails.application.config.agreements.find { it.id == :terms_of_service }
  end

  def privacy
    @agreement = Rails.application.config.agreements.find { it.id == :privacy_policy }
  end

  def reset_app
    # Hotwire Native needs an empty page to route authentication and reset the app.
    # We can't head: 200 because we also need the Turbo JavaScript in <head>.
  end

  # Toggle cookie that activates the in-app debug panel (see
  # app/javascript/controllers/debug_panel_controller.js). Beta testers only.
  # Persistent cookie so the panel survives app launches in TestFlight.
  def toggle_debug
    head :forbidden and return unless current_user&.beta_tester?
    if cookies[:shuby_debug] == "1"
      cookies.delete(:shuby_debug)
    else
      cookies.permanent[:shuby_debug] = "1"
    end
    redirect_back fallback_location: settings_path
  end

  # Temporary diagnostic page for debugging native navigation
  def native_debug
    render inline: <<~HTML, layout: "application"
      <% content_for :hide_navbar, true %>
      <div style="padding:20px;font-family:monospace;font-size:14px;">
        <h2 style="font-size:18px;margin-bottom:16px;">Native Debug</h2>
        <div id="debug-output" style="background:#f0f0f0;padding:12px;border-radius:8px;line-height:1.8;">
          Loading...
        </div>
        <div style="margin-top:20px;">
          <a href="/today" style="display:inline-block;padding:12px 24px;background:#0159B5;color:white;border-radius:8px;text-decoration:none;margin:4px;">Link: /today</a>
          <a href="/settings" style="display:inline-block;padding:12px 24px;background:#0159B5;color:white;border-radius:8px;text-decoration:none;margin:4px;">Link: /settings</a>
          <a href="/today" data-turbo="false" style="display:inline-block;padding:12px 24px;background:#C500A2;color:white;border-radius:8px;text-decoration:none;margin:4px;">No-Turbo: /today</a>
        </div>
      </div>
      <script type="module">
        const el = document.getElementById('debug-output');
        const lines = [];
        lines.push('UA: ' + navigator.userAgent.substring(0, 80));
        lines.push('HTML class: ' + document.documentElement.className);
        lines.push('Turbo loaded: ' + (typeof Turbo !== 'undefined'));
        lines.push('Turbo.session: ' + (typeof Turbo !== 'undefined' && !!Turbo.session));
        lines.push('Stimulus: ' + (typeof window.Stimulus !== 'undefined'));
        try { lines.push('Turbo version: ' + (Turbo.Navigator ? 'yes-Navigator' : 'no-Navigator')); } catch(e) { lines.push('Turbo check error: ' + e.message); }
        lines.push('RubyNative bridge: ' + (typeof webkit !== 'undefined' && !!webkit.messageHandlers));
        lines.push('importmap: ' + (document.querySelector('script[type=importmap]') ? 'present' : 'MISSING'));
        lines.push('JS modules: working');
        el.textContent = lines.join('\\n');
      </script>
    HTML
  end
end
