module ScrapperHelper
	def hinted_text_field_tag(name, value = "Click and enter text", options={})
  	
  	text_field_tag name, value, {:onclick => "if($(this).val() == '#{value}'){$(this).val('');console.log('hehe');}", :onblur => "if($(this).val() == ''){$(this).val('#{value}');}"}.merge(options)
	end
end
