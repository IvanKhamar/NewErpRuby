# The React app (frontend/, built into public/ui). Static files are served by Rails' public file server; this action
# answers the client-side routes (/ui/orders/42) with index.html, so a reload or a shared link opens the right page.
# Anonymous on purpose: the page holds no data; the app asks the API, which checks the login cookie.
class UiController < ApplicationController
  INDEX = Rails.public_path.join("ui/index.html")

  def show
    if INDEX.exist?
      render file: INDEX, layout: false, content_type: "text/html"
    else
      render plain: "The React app is not built: run `npm run build` in frontend/ (or use the ui service).",
             status: :not_found
    end
  end
end
