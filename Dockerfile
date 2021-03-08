FROM ubuntu:18.04

# インストール
RUN apt-get update -q && apt-get upgrade -yq && apt-get install -y --no-install-recommends \
        git \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# ユーザ作成
ARG USERNAME=developer
ARG ROBOCON_WS=/home/${USERNAME}/catkin_ws
RUN useradd --create-home --home-dir /home/${USERNAME} --shell /bin/bash --user-group --groups adm,sudo,video,audio ${USERNAME} \
    && echo ${USERNAME}:${USERNAME} | chpasswd \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ディレクトリ作成
RUN mkdir -p /home/${USERNAME}/.config/catkin/verb_aliases \
    && mkdir -p /home/${USERNAME}/.ros/log \
    && mkdir -p /home/${USERNAME}/.gazebo/log

# 永続化したい設定を.bashrc/.bash_profileに追加
COPY ./export_env /home/${USERNAME}/export_env
RUN cat /home/${USERNAME}/export_env \
    | sed "s@{{ROBOCON_WS}}@${ROBOCON_WS}@g" \
    | sed "s@{{ROS_DISTRO}}@${ROS_DISTRO}@g" \
    | tee -a /home/${USERNAME}/.bashrc \
          >> /home/${USERNAME}/.bash_profile \
    && rm /home/${USERNAME}/export_env

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/

# 環境変数の設定
ENV TZ Asia/Tokyo

# 初期ディレクトリの指定
WORKDIR ${ROBOCON_WS}

# 起動時の実行コマンドの指定
COPY ./entrypoint.sh /entrypoint.sh
RUN chown ${USERNAME}:${USERNAME} /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && sed -i'' -e "s/^\(DEVELOPER_NAME\)=.*$/\1=${USERNAME}/g" /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "bash" "-l" ]
