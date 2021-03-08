ARG ROS_DISTRO=melodic
FROM osrf/ros:${ROS_DISTRO}-desktop-full

# インストール
RUN apt-get update -q && apt-get upgrade -yq && apt-get install -y --no-install-recommends \
        git \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# ユーザ作成
ARG USERNAME=developer
RUN useradd --create-home --home-dir /home/${USERNAME} --shell /bin/bash --user-group --groups adm,sudo,video,audio ${USERNAME} \
    && echo ${USERNAME}:${USERNAME} | chpasswd \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# ROSの初期化
#------------------------------------------------
RUN test -f /etc/ros/rosdep/sources.list.d/20-default.list \
    && rm /etc/ros/rosdep/sources.list.d/20-default.list
RUN rosdep init \
    && gosu ${USERNAME} rosdep update \
    && mkdir -p /home/${USERNAME}/.config/catkin/verb_aliases \
    && mkdir -p /home/${USERNAME}/.ros/log \
    && mkdir -p /home/${USERNAME}/.gazebo/log

# ワークスペース作成
#------------------------------------------------
ARG ROBOCON_WS=/home/${USERNAME}/catkin_ws
RUN mkdir -p ${ROBOCON_WS}/src/burger_war_kit \
    && mkdir -p ${ROBOCON_WS}/logs
# 必要なファイルを展開
COPY ./docker/templates/ /home/${USERNAME}/

# 永続化したい設定を.bashrc/.bash_profileに追加
RUN cat /home/${USERNAME}/export_env \
    | sed "s@{{ROBOCON_WS}}@${ROBOCON_WS}@g" \
    | sed "s@{{ROS_DISTRO}}@${ROS_DISTRO}@g" \
    | tee -a /home/${USERNAME}/.bashrc \
          >> /home/${USERNAME}/.bash_profile \
    && rm /home/${USERNAME}/export_env

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/

# 環境変数の設定
ENV TZ Asia/Tokyo

# sudo時に引き継ぐ変数の設定
RUN echo 'Defaults        env_keep += "http_proxy https_proxy ftp_proxy no_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"' >> /etc/sudoers

# 初期ディレクトリの指定
WORKDIR ${ROBOCON_WS}

# 起動時の実行コマンドの指定
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chown ${USERNAME}:${USERNAME} /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && sed -i'' -e "s/^\(DEVELOPER_NAME\)=.*$/\1=${USERNAME}/g" /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "bash" "-l" ]

# 初期ディレクトリの指定
WORKDIR ${ROBOCON_WS}
