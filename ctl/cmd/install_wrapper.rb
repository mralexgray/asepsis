def cmd_install_wrapper(options)
    force = options[:force]

    unless force
      # prevent installing on future OS versions
      os_version_check()
    end

    # sanity check
    sys("sudo rm -rf \"#{DS_LIB_RELOCATED_FOLDER}\"") if File.exists? DS_LIB_RELOCATED_FOLDER and force
    die("wrapper framework seems to be installed (#{DS_LIB_RELOCATED_FOLDER} exists), to reinstall please run: \"asepsisctl uninstall_wrapper\" first") if File.exists? DS_LIB_RELOCATED_FOLDER

    # make panic backup first
    unless File.exists? DS_LIB_PANIC_BACKUP_FOLDER then
      sys("sudo cp -r \"#{DS_LIB_FOLDER}\" \"#{DS_LIB_PANIC_BACKUP_FOLDER}\"")
    end

    # make backup
    sys("sudo cp -r \"#{DS_LIB_FOLDER}\" \"#{DS_LIB_BACKUP_FOLDER}\"")
    sys("sudo touch \"#{DS_LIB_ASEPSIS_REV}\"")

    # replace DesktopServicesPriv inplace
    sys("sudo cp -r \"#{DS_LIB_FOLDER}\" \"#{DS_LIB_RELOCATED_FOLDER}\"")
    sys("sudo \"#{RESOURCES_PATH}/install_name_tool\" -id \"#{DS_LIB_RELOCATED_FOLDER}/DesktopServicesPriv\" \"#{DS_LIB_RELOCATED_FOLDER}/DesktopServicesPriv\"")
    # apply code signatures only under Mavericks and higher
    sys("sudo \"#{RESOURCES_PATH}/codesign\" --force --sign - \"#{DS_LIB_RELOCATED_FOLDER}/DesktopServicesPriv\"") unless lions?
    sys("sudo \"#{RESOURCES_PATH}/codesign\" --force --sign - \"#{DS_WRAPPER_SOURCE_PATH}\"") unless lions?
    sys("sudo cp \"#{DS_WRAPPER_SOURCE_PATH}\" \"#{DS_LIB_FOLDER}/DesktopServicesPriv\"")
    sys("sudo rm -rf \"#{DS_LIB_FOLDER}/_CodeSignature\"")
  end