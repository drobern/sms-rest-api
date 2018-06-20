defmodule SMSRest.SMSCore do
    
    def is_phonenumber_provisioned(%{
        "phoneNumber"=> phoneNumber, 
        "accountId"=> accountId, 
        "principalId"=> principalId
        } = params) do
        case SmsCloudlinkDbMock.get_phone_numbers(accountId, principalId) do
            {:ok, numbers} ->
                IO.inspect numbers
                {:ok, numbers}
            {:error, :not_found} ->
                IO.write("Number #{phoneNumber} is not provisoned for sms")
                {:error, :not_found}
        end
    end

    def is_user_provisioned(%{
        "from"=> from,
        "accountId"=> accountId, 
        "principalId"=> principalId
        } = params) do
            is_phonenumber_provisioned(Map.put(params,"phoneNumber", from))
    end

    def is_user_provisioned(%{
        "accountId"=> accountId, 
        "principalId"=> principalId
        } = params) do
        case SmsCloudlinkDbMock.get_phone_numbers(accountId, principalId) do
            {:ok, [number|[]]} ->
                IO.inspect number
                {:ok, number}
            {:ok, _} ->
                {:error, :multiple_numbers}    
            {:error, :not_found} ->
                IO.write("account id #{accountId} is not provisoned for sms")
                {:error, :not_found}
        end
    end

    def send_message(params) do
        
    end
end