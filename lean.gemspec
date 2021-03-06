Gem::Specification.new do |s|
  s.name        = 'lean'
  s.version     = '1.0.0'
  s.date        = '2015-08-20'
  s.summary     = "Lean"
  s.description = "Gangsta Lean ruby web framework"
  s.authors     = ["m4rkw"]
  s.email       = 'm@rkw.io'
  s.files       = [
                    "lib/lean.rb",
                    "lib/lean/auth.rb",
                    "lib/lean/config.rb",
                    "lib/lean/config/config.rb",
                    "lib/lean/config/routes.rb",
                    "lib/lean/controller.rb",
                    "lib/lean/cookie.rb",
                    "lib/lean/db.rb",
                    "lib/lean/flash.rb",
                    "lib/lean/form.rb",
                    "lib/lean/httpfilemapper.rb",
                    "lib/lean/log.rb",
                    "lib/lean/mappedfile.rb",
                    "lib/lean/model.rb",
                    "lib/lean/modelquery.rb",
                    "lib/lean/renderer.rb",
                    "lib/lean/request.rb",
                    "lib/lean/router.rb",
                    "lib/lean/session.rb",
                    "lib/lean/threadwatch.rb",
                    "lib/lean/uritool.rb",
                    "lib/lean/user.rb",
                    "lib/lean/view/_404.erb",
                    "lib/lean/view/layout/main.erb",
                    "lib/lean/view/form/passwordinput.erb",
                    "lib/lean/view/form/recaptcha.erb",
                    "lib/lean/view/form/textinput.erb",
                    "lib/lean/view/form/submit.erb",
                    "lib/lean/view/form/textarea.erb"
                  ]
  s.homepage    = 'https://github.com/m4rkw/lean'
  s.license     = 'MIT'
  s.add_runtime_dependency "sequel", ["~> 4.25"]
  s.add_runtime_dependency "htmlentities", ["~> 4.3"]
  s.add_runtime_dependency "rack", ["~> 2.0"]
  s.add_runtime_dependency "migrations", ["~> 1.0"]
end
