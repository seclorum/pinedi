--
-- Persistent data: user-based data that must be recorded
-- goal: anything you put in user_data, will be available
-- in the next app session, *after* you call sync_user_data()
--
user_data_path = (MOAIEnvironment.documentDirectory or "./") .. "/_pixels_never_die_user_data_.lua"
----print ("User data path is: " .. user_data_path)
user_data_f = loadfile(user_data_path) or nil
user_data = {}
--
-- call sync_user_data any time you modify or update user_data in any way
function sync_user_data()
  serializer = MOAISerializer.new ()
  serializer:serialize ( user_data )
  user_data_Str = serializer:exportToString ()

  --compiled = string.dump ( loadstring ( user_data_Str, '' )) 
  --print("Writing User Data: ", user_data_path)
  user_data_file = io.open (user_data_path, 'wb' )
  -- attempt to save the file ..
  if (user_data_file ~= nil) then
    user_data_file:write ( user_data_Str )
    user_data_file:close ()
  end
end

-- clear the user_data completely
function reset_user_data()
  user_data.app_name = MAIN_APP_NAME
  user_data.start_date = os.time()
  sync_user_data() -- every time you use this, it happens.  from that point on, the data will persist.
end

-- on app start, we load user_data
if (user_data_f ~= nil) then
  user_data = user_data_f() -- we de-serialize our loads
  --print ("Reading User Data: ", user_data)
else
  reset_user_data() -- or, we begin anew ..
end

print(table.show(user_data, "user_data"))
