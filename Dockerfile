FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y git curl gperf wget python3 python3-pip libssl-dev libbz2-dev libosmesa6-dev libgles2-mesa-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrandr-dev libxrender-dev libcups2-dev libfontconfig1-dev libdbus-1-dev libgconf2-dev  libudev-dev libpci-dev libcap-dev libxtst-dev libpulse-dev libexpat1-dev libatk1.0-dev libatk-bridge2.0-dev libatspi2.0-dev libxcomposite-dev libxdamage-dev libnss3-dev libasound2-dev libjsoncpp-dev lsb-release 
RUN apt-get clean

# Clone Chromium source code
RUN mkdir /chromium && cd /chromium && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH="/chromium/depot_tools:${PATH}"

RUN touch .gclient \
 #&& echo "solutions = [{'custom_deps': {}, 'custom_vars': {}, 'deps_file': '.DEPS.git', 'managed': False, 'name': 'src', 'url': 'git@github.com:chromium.googlesource.com/chromium/src.git@refs/remotes/origin/main'}]" > .gclient \
 && echo "solutions = [{'custom_deps': {}, 'custom_vars': {}, 'deps_file': '.DEPS.git', 'managed': False, 'name': 'src', 'url': 'git@github.com:chromium.googlesource.com/chromium/src.git@refs/tags/113.0.5672.77'}]" > .gclient \
 && echo "target_os = ['chromeos']" >> .gclient \
 && echo "target_cpu = ['arm']" >> .gclient

RUN mv /.gclient /chromium

RUN git config --global http.postBuffer 924288000

RUN mkdir /chromium/src && cd /chromium && git clone https://chromium.googlesource.com/chromium/src.git 

RUN cd /chromium/src && git fetch origin tag 113.0.5672.77

RUN cd /chromium/src && git checkout refs/tags/113.0.5672.77 -b my_chrome


# Install build dependencies
RUN cd /chromium && gclient sync --with_branch_heads --with_tags

RUN cd /chromium && gclient runhooks 

RUN cd /chromium/src && ./build/linux/sysroot_scripts/install-sysroot.py --arch=arm	


RUN sed -i 's/dev_list="\${dev_list} snapcraft"/dev_list="\${dev_list}"/' /chromium/src/build/install-build-deps.sh

RUN apt-get install -y sudo

RUN cd /chromium/src && ./build/install-build-deps.sh --no-chromeos-fonts --arm --no-prompt

RUN apt-get clean 


### Note make custom changes - curretly manual
# docker cp  C:\PMDEV\UBENW_rasp_chrome\resources\images\offline_internals.png heuristic_goldstine:/chromium/src/components/neterror/images
# docker cp  C:\PMDEV\UBENW_rasp_chrome\resources\neterror.html heuristic_goldstine:/chromium/src/components/neterror/


#RUN cd /chromium/src &&  rm -r out/Default

#RUN cd /chromium/src && gn gen out/Default --args='target_cpu="arm" target_os="linux" arm_float_abi="hard" is_debug=false is_component_build=true ffmpeg_branding="Chrome" use_system_libdrm=false use_xkbcommon=true use_udev=true enable_nacl=false enable_widevine=true enable_vulkan=false use_cups=true'


# Build Chromium
#RUN cd /chromium/src && autoninja -C out/Default chrome

# Archive Build
#RUN tar -czvf /chromium/build_chrome_offlinepage.tar.gz  --exclude=gen --exclude=obj --exclude=pyproto --exclude=resources --exclude=Packages --exclude='newlib_*' --exclude='nacl_bootstrap*' --exclude='glibc_*' --exclude='clang_*' --exclude='irt_*' --exclude='*.ninja*' --exclude='*.runtime_deps' --exclude='*.info' --exclude='*.TOC' /chromium/src/out/Default

#Unarchive build
#tar -xzvf /chromium/build_chrome.tar.gz -C /chromium/build_chrome

#move to local
# docker cp heuristic_goldstine:/chromium/build_chrome_offlinepage.tar.gz C:\PMDEV\UBENW_rasp\

# Set up the entrypoint
#ENTRYPOINT ["/chromium/chrome", "--no-sandbox", "--no-first-run", "--user-data-dir=/root/chromium-profile", "--single-process", "--start-maximized", "--start-fullscreen", "--kiosk", "http://localhost"]
