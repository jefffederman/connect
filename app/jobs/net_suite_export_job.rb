class NetSuiteExportJob < ActiveJob::Base
  def perform(operation, sync_summary_id, net_suite_connection_id,
              namely_profile_id, namely_profile_name,
              netsuite_employee, netsuite_id = nil)
    unless ["create", "update"].include? operation
      logger.error("Unknown operation #{operation}")
      return
    end

    if operation == "update" && netsuite_id == nil
      logger.error("Update operation requires netsuite_id")
      return
    end

    connection = NetSuite::Connection.find_by(id: net_suite_connection_id)
    unless connection
      logger.error("Connection not found #{net_suite_connection_id}")
      return
    end

    netsuite_client = connection.client

    namely_client = connection.installation.namely_connection

    profile = namely_client.profiles.build(id: namely_profile_id,
                                           name: namely_profile_name)

    employee = NetSuite::EmployeeExport.new(profile: profile,
                                            attributes: netsuite_employee,
                                            netsuite_client: netsuite_client,
                                            netsuite_id: netsuite_id)


    result = case operation
             when "create"
               employee.create
             when "update"
               employee.update
             end

    ProfileEvent.create(
      sync_summary_id: sync_summary_id,
      profile_id: result.profile_id,
      profile_name: result.name,
      error: result.error
    )
  end
end
