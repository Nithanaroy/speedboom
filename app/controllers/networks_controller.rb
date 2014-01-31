require 'json'
class NetworksController < ApplicationController
  before_action :set_network, only: [:show, :edit, :update, :destroy]

  # GET /networks
  # GET /networks.json
  def index
    cmd = `cd ../dispatch-proxy/bin; node dispatch.js list`
    @networks = JSON.parse(cmd)
    # @networks = Network.all
  end

  # GET /networks/1
  # GET /networks/1.json
  def show
  end

  # GET /networks/new
  def new
    @network = Network.new
  end

  # GET /networks/1/edit
  def edit
  end

  def start_dispatch
    puts params
    unless params[:selected_networks].nil?
      network_string = params[:selected_networks].first.keys.join(' ')
      cmd = "cd ../dispatch-proxy/bin; node dispatch.js start --http --debug #{network_string} &"
      puts "Executing command: #{cmd}"
      cmd_result = system(cmd)
      if cmd_result
        @@pid = (`ps -e | grep "node dispatch.j[s]"`).split(' ').first
        puts "Created process with PID: #{@@pid}"
        cmd = 'networksetup -setwebproxy "Wi-Fi" localhost 8080' # TODO : Wifi Connection is a must
        cmd_result = system(cmd)
        if cmd_result
          render :json => {'msg' => 'Yo Yo! SpeedBoom started. Enjoy high speeds!', 'css_class' => 'alert-success', 'state-change' => true}
          return
        else
          render :json => {'msg' => 'SpeedBoom started but couldn\'t set Wifi proxy to localhost 8080. Manually change', 'css_class' => 'alert-danger', 'state-change' => true}
          return
        end
      else
        render :json => {'msg' => 'Couldn\'t start dispatch', 'css_class' => 'alert-danger', 'state-change' => true}
        return  
      end
    else
      render :json => {'msg' => 'Select some networks and then press start', 'css_class' => 'alert-info', 'state-change' => false}
      return
    end    
    render :json => {'msg' => 'Something weird happened', 'css_class' => 'alert-info', 'state-change' => true}
  end

  def stop_dispatch
    unless defined? @@pid
      render :json => {'msg' => 'Hmmm... guess what those On / Off button do??', 'css_class' => 'alert-info', 'state-change' => false}
      return  
    end
    cmd = "kill -SIGINT #{@@pid} &"
    cmd_result = system(cmd)
    cmd_result = true
    if cmd_result
      cmd = 'networksetup -setwebproxystate "Wi-Fi" off'
      cmd_result = system(cmd)
      if cmd_result
        render :json => {'msg' => 'SpeedBoom stopped successfully. Try again soon!', 'css_class' => 'alert-info', 'state-change' => true}
        return  
      else
        render :json => {'msg' => 'SpeedBoom stopped but couldn\'t set WiFi network connection to No Proxy. Please do it manually.', 'css_class' => 'alert-danger', 'state-change' => true}
        return
      end
    else
      render :json => {'msg' => "Error stopping SpeedBoom. Please close dispatcher [#{@@pid}] manually!", 'css_class' => 'alert-danger', 'state-change' => true}
      return
    end
  end

  # POST /networks
  # POST /networks.json
  def create
    @network = Network.new(network_params)

    respond_to do |format|
      if @network.save
        format.html { redirect_to @network, notice: 'Network was successfully created.' }
        format.json { render action: 'show', status: :created, location: @network }
      else
        format.html { render action: 'new' }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /networks/1
  # PATCH/PUT /networks/1.json
  def update
    respond_to do |format|
      if @network.update(network_params)
        format.html { redirect_to @network, notice: 'Network was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @network.destroy
    respond_to do |format|
      format.html { redirect_to networks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_network
      @network = Network.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def network_params
      params.require(:network).permit(:name, :ip_four)
    end
end
