namespace :be_strong do
  desc 'Apply strong parameter method and remove attr_accessible, attr_protected.'
  task convert: :environment do |task, args|
    params = {}
    if args.extras.count >= 1
      params[:controller_path] = args.extras[0]
    end
    if args.extras.count >= 2
      params[:model_path] = args.extras[1]
    end
    result = BeStrong::Converter.convert(params)
    result[:applied].each{|file| puts "Apply strong parameter: #{file}"}
    result[:removed].each{|file| puts "Remove attr_[accessible|protected]: #{file}"}
  end
end
