import { Socket, SocketConnectOpts } from "node:net";
export default class ServerSocket extends Socket {
  intervalConnect = false;
  intervalId: NodeJS.Timeout | undefined;
  options: SocketConnectOpts;
  private launchIntervalConnect() {
    if (this.intervalConnect) return;
    this.intervalConnect = true;
    this.intervalId = setInterval(this.start, 5000);
  }

  public clearIntervalConnect() {
    if (!this.intervalConnect) return;
    clearInterval(this.intervalId);
    this.intervalConnect = false;
  }

  public constructor(options: SocketConnectOpts) {
    super();

    super.on("connect", () => {
      this.clearIntervalConnect();
    });
    super.on("ready", () => {
      console.log("socket is ready");
    });

    super.on("error", (err: any) => {
      console.log("error occur", err, ",try to reconnect");

      this.launchIntervalConnect();
    });

    super.on("close", () => {
      console.log(
        new Date().toLocaleTimeString(),
        "socket close, try to reconnect"
      );
      this.launchIntervalConnect();
    });
    this.options = options;
  }

  start = (connectionListener?: () => void): void => {
    if (connectionListener) {
      super.connect(this.options, connectionListener);
    } else {
      super.connect(this.options);
    }
  };
}
