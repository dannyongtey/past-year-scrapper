module ScrapperHelper
	def hinted_text_field_tag(name, value = "Click and enter text", options={})
  	
  	text_field_tag name, value, {:onclick => "if($(this).value == '#{value}'){$(this).value = ''; console.log('hehe');}", :onblur => "if($(this).value == ''){$(this).value = '#{value}'}" }.merge(options)
	end
end
