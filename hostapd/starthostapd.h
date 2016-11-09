#include "utils/includes.h"
#ifndef CONFIG_NATIVE_WINDOWS
#include <syslog.h>
#include <grp.h>
#endif /* CONFIG_NATIVE_WINDOWS */

#include "utils/common.h"
#include "utils/eloop.h"
#include "utils/uuid.h"
#include "crypto/random.h"
#include "crypto/tls.h"
#include "common/version.h"
#include "drivers/driver.h"
#include "eap_server/eap.h"
#include "eap_server/tncs.h"
#include "ap/hostapd.h"
#include "ap/ap_config.h"
#include "ap/ap_drv_ops.h"
#include "fst/fst.h"
#include "config_file.h"
#include "eap_register.h"
#include "ctrl_iface.h"

int start_hostapd(const char *config_fname);
