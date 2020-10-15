require 'sinatra/base'
require "sinatra/config_file"
require 'sinatra-websocket'
require './models/init.rb'

class App < Sinatra::Base

  register Sinatra::ConfigFile

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, "5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y49t4hgrd56g8u84gfmjhdmhh,xg544ncd"
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  get "/" do
    logger.info "params"
    logger.info params
    logger.info "--------------"
    logger.info session["session_id"]
    logger.info session.inspect
    logger.info "Configurations"
    logger.info settings.db_adapter
    logger.info "--------------"
    @document = Document.order(:date).reverse.all
    erb :index
  end

  get "/miwebsoket" do #para nico
    if !request.websocket?
      redirect "/"
    else
      request.websocket do |ws|
        @connect = {id_user: session[:user_id], socket: ws}
        ws.onopen do
          settings.sockets << @connect
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each {|s| s[:socket].send(msg)}}
        end
        ws.onclose do
          settings.sockets.delete(@connect)
        end
      end
    end
  end

  before do
    if session[:isLogin]
      @userName = User.find(id: session[:user_id])
      @not = NotificationUser.where(user_id: @userName.id, seen: 'f')
      @page = (request.path_info)
      if session[:type]
        @layoutEnUso = :layout_admin
        @page = (request.path_info)
      else
        @layoutEnUso = :layout_users
        @page = (request.path_info)
      end
    end
    @urlAdmin = ["/all_category","/all_document","/modify_document"]
    if !session[:type] &&  @urlAdmin.include?(request.path_info)
      redirect "/profile"
    end
    if session[:type] &&  "/documents" == (request.path_info)
      redirect "/all_document"
    end
    @urlUser = ["/profile","/subscriptions", "/edit_user","/documents","/notification","/view_document"]
    if !session[:isLogin]  &&  @urlUser.include?(request.path_info)
      redirect "/"
    end
  end

  post "/new_user" do #FUNNCIONA
    if user = User.find(dni: params[:dni])
      [400, {}, "ya existe el usuario"] #Crear UI
    else
      @newUserName = User.new(name: params[:name],surname: params[:surname],dni: params[:dni],email: params[:email],password: params[:password],rol: params[:rol])
      @newUserName.admin=false
      if @newUserName.save
        @errormsg ="La cuenta fue creada."
        redirect "/profile"
      else
        @errormsg ="La cuenta no fue creada."
        redirect "/"
      end
    end
  end

  post "/create_user" do #FUNNCIONA
    if user = User.find(dni: params[:dni])
      [400, {}, "ya existe el usuario"]
    else
      @newUserName = User.new(name: params[:name],surname: params[:surname],dni: params[:dni],email: params[:email],password: params[:password],rol: params[:rol])
      if (params["type"]=="Administrador")
        @newUserName.admin=true
      else
        @newUserName.admin=false
      end
      @newUserName.save
    end
  end

  post "/user_login" do #FUNNCIONA
    if @userName = User.find(email: params[:email])
      if @userName.password == params[:password]
        session[:isLogin] = true
        session[:user_id] = @userName.id
        session[:type] = @userName.admin
        redirect "/profile"
      else
        @errormsg ="La contraeña es incorrecta."
        redirect "/"
      end
    else
      @errormsg ="El Email es incorrecto."
      redirect "/"
    end
  end

  get "/profile" do #FUNNCIONA
    @page_name = "Inicio"
    @User = User.find(id: session[:user_id])
    @document = Document.where(users: @User)
    erb :profile, :layout =>@layoutEnUso
  end

  post "/edit_user" do #FUNCIONA
    if (params[:name] != "")
      @userName.update(name: params[:name])
    end
    if (params[:surname] != "")
      @userName.update(surname: params[:surname])
    end
    if (params[:dni] != "")
      @userName.update(dni: params[:dni])
    end
    if (params[:password] != "")
      @userName.update(password: params[:password])
    end
    if (params[:rol] != "")
      @userName.update(rol: params[:rol])
    end
    redirect "/profile"
  end

  post "/delete_user" do #FUNCIONA
    @userDelete = User.find(id: session[:user_id])
    @userDelete.remove_all_categories
    @userDelete.remove_all_documents
    @notification = Notification.where(users: @userDelete).all
    if !@notification.empty?
      @notification.each do |element|
        element.remove_all_notifications
        element.delete
      end
    end
    if @userDelete.delete
      session.clear
      redirect '/'
    end
  end

  get "/documents" do #FUNCIONA
    @page_name = "Documentos"
    @document = Document.order(:name).all
    @allCat = Category.order(:name).all
    erb :documents, :layout =>@layoutEnUso
  end


















  get "/all_document" do #FUNCIONA
    @page_name = "Documentos"
    @user_name = User.find(id: session[:user_id])
    @all_document = Document.order(:name).all
    @all_category = Category.order(:name).all
    @usersName = User.order(:name).all
    erb :all_document, :layout =>@layoutEnUso
  end

  post '/create_document' do #FUNCIONA
    @filename = params[:PDF][:filename]
    @src =  "/public/PDF/#{@filename}"
    file = params[:PDF][:tempfile]
    direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    date = Time.now.strftime("%Y-%m-%d")
    dateNot = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    chosenCategory = Category.find(id: params[:cat])
    @prob = User.all
    if !(@docExi= Document.find(name: params[:name])) #|| @docExi= Document.find(description: params[:description]))
      @doc = Document.new(name: params['name'], description: params[:description], fileDocument:  direction, category_id: chosenCategory.id, date: date)
      @doc.save
      @notification = Notification.new(description: "etiquetaron", date: dateNot, document_id: @doc.id)
      @notification.save
      @User_Names = params[:mult]
      @User_Names &&  @User_Names.each do |element|
        @doc.add_user(element)
        @notification.add_user(element)
        message = @notification.description
        notifyUser(element,message)
      end
      @notification_cat =  Notification.new(description: "categoria", date: dateNot, document_id: @doc.id)
      @notification_cat.save
      @cat_notification = Category.find(id: chosenCategory.id)
      @cat_notification.users.each do |element|
        @notification_cat.add_user(element)
      end
      @errormsg ="El documento fue cargado."
      @allCat = Category.order(:name).all
      @userName = User.find(id: session[:user_id])
    else
      @userCreate = User.order(:name).all
      @categories = Category.order(:name).all

      @errormsg = "El Documento/descripción ya existen"
    end
  end

  post "/select_document" do #FUNCIONANDO
    @page_before_name = "Documentos"
    @page_before = "/all_document"
    @page_interna = "Editar Documento"
    @modDocument = Document.find(id: params[:theId])
    @allCategory = Category.order(:name).all
    @modCat = Category.find(id: @modDocument.category_id)
    @usersTag = User.where(documents: @modDocument)
    @usersName = User.except(@usersTag).all
    erb :modify_document, :layout =>@layoutEnUso
  end

  post "/modify_document" do #FUNCIONANDO Verificar lo de etiquetar y sumar notificaciones...
    @newModification = Document.find(id: params[:theId])
    if (params[:newName]!= "")
      @newModification.update(name: params[:newName])
    end
    if (params[:description] != "")
      @newModification.update(description: params[:description])
    end
    if (params[:cate])
      @newModification.update(category_id: params[:cate])
    end
    if (params[:mult])
      @newModification.remove_all_users
      @User_Ids = params[:mult]
      @User_Ids.each do |element|
        @newModification.add_user(element)
      end
    end
  end

  post "/delete_document" do #FUNCIONA
    @pdfDelete = Document.find(id: params[:theId])
    @pdfDelete.remove_all_users
    @notification = Notification.where(document_id: @pdfDelete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdfDelete.delete
  end

  get "/all_category" do #FUNCIONA
    @page_name = "Categorias"
    @allCategory  = Category.order(:name).all
    # @catSelect = Category.all
    erb :all_category, :layout =>@layoutEnUso
  end

  post "/create_category" do #FUNCIONA
    if cat = Category.find(name: params[:name])
      [500, {}, "ya existe la categoria"]
    else
      cat = Category.new(name: params[:name],description: params[:description] )
      if cat.save
      else
        [500, {}, "Internal Server Error"]
      end
    end
  end

  get "/notification" do  #FUNCIONA
    @page_name = "Notificaciones"
    Note = Struct.new(:notificacion,:documento,:info)
    @documentNotificationEtq = []
    @documentNotificationCat = []
    @notificaciones_usuario = NotificationUser.where(user_id: session[:user_id]).all
     @notificaciones_usuario && @notificaciones_usuario.each do |element|
        @not = Notification.find(id: element.notification_id)
        @notification = Note.new
        if @not.description == 'etiquetaron'
          @notification.notificacion = @not
          @notification.documento = (Document.find(id: @not.document_id))
          @notification.info = (element)
          @documentNotificationEtq << (@notification)
        else
          @notification.notificacion = @not
          @notification.documento =(Document.find(id: @not.document_id))
          @notification.info = (element)
          @documentNotificationCat << (@notification)
        end
      end
      erb :notification, :layout =>@layoutEnUso
    end

    post "/delete_notification" do #FUNCIONA
      @notificated = Notification.find(id: params[:theId])
      @Seen = NotificationUser.find(notification_id: @notificated.id, user_id: @userName.id)
      @Seen.delete
    end

    post "/mark_notification" do #FUNCIONA
        @notificated = Notification.find(id: params[:theId])
        @Seen = NotificationUser.find(notification_id: @notificated.id, user_id: @userName.id)
        if @Seen.seen == false
          @Seen.update(seen: true)
        else
          @Seen.update(seen: false)
        end
    end

    post "/see_document" do #FUNCIONA
      unless params[:nombre] == "Perfil"
        @page_before_name = params[:nombre]
        @page_before = params[:camino]
        @page_interna = "Documento"
      else
        @page_name = "Documento"
      end
      @documento = Document.find(id: params[:theId])
      erb :view_document, :layout =>@layoutEnUso
    end

    get "/subcriptions" do #FUNCIONA
      @page_name = "Suscripciones"
      @subcriptions = Category.where(users: @userName)
      @allCategory = Category.except(@subcriptions).all
      erb :subcriptions, :layout =>@layoutEnUso
    end

    post "/delete_subcriptions" do
      @subscription_to_delete = Category.find(id: params[:idSubcriptions])
      @userName = User.find(id: session[:user_id])
      @userName.remove_category(@subscription_to_delete)
    end

    post "/new_suscription" do
      @subscription = Category.find(id: params[:id_cat])
      @userName.add_category(@subscription)
    end

  post "/modify_category" do #FUNCIONA
      if  @catUp = Category.find(id: params[:modifyId])
        @catUp.update(name: params[:name],description: params[:description])
        unless @catUp.save
          [500, {}, "Internal Server Error"]
        end
    end
  end

  post "/delete_category" do #FUNCIONA
    @catDelete = Category.find(id: params['idDelete'])
    @catSelect = Category.find(id: params['idSelect'])
    @Document = Document.where(category_id: @catDelete.id)
    @Document.each do |element|
      element.update(category_id: @catSelect.id)
    end
    @allDocs = Document.where(category_id: @catDelete.id)
    if @allDocs.empty?
        @catDelete.remove_all_users
        @catDelete.delete
    end
  end

  get "/logout" do #FUNNCIONA
    session.clear
    redirect '/'
  end

  def notifyUser(user, message) #Funciona
    settings.sockets.each do |s|
      if s[:id_user] == user
        s[:socket].send(message)
      end
    end
  end

  post "/documents_filter" do
    @page_name = "Documentos"
    @all_category = Category.order(:name).all
    if params[:document_id]
      @document = Document.where(id: params[:document_id]).all
    else
      if params[:filter] == "date0"
        @document = Document.order(:date).reverse.all
      else
        @document = Document.order(:name).all
      end
      if  params[:category_id]
        @documentCat = Document.where(category_id: params[:category_id]).all
        @document3 = []
        @document.each do |element|
          if @documentCat.include?(element)
            @document3 << element
          end
        end
        @document = @document3
      end
      # if params[:dateDoc] != ""
      #   newDate = newDat (params[:dateDoc])
      #   # newDate = "2020-10-15"
      #   @document2 = Document.where(date: newDate).all
      #   @document = @document2
      # end
    end
    if session[:type]
      @all_document = @document
      @usersName = User.order(:name).all
      erb :all_document, :layout =>@layoutEnUso
    else
      @all_document = @document
      erb :documents, :layout =>@layoutEnUso
    end
  end

  def filter(newDate, nameDoc, order, category) #Mejorar
    if nameDoc != ""
      @document = Document.find(name: nameDoc)
      return @document
    end
    # if order != ""
    #   if order == date0
    #     @document = Document.all.order(:date)
    #   else
    #     @document = Document.all.order(:name)
    #   end
    # end
    # if category != ""
    #   @idCategory = Category.find(id: params[:category])
    #   @document = Document.where(category_id: @idCategory.id).all
    # end
    # if newDate != ""
    #   @document2 = @document.where(date: newDate).all
    #   @document = @document2
    # end
    @allCat = Category.all
    erb :documents, :layout =>@layoutEnUso
  end

  def newDat(date)
    newDate = ""
    case date[0,3]
    when "Jan"
      newDate = date[8,12] + "-" + "01" + "-" + date[4,6]
    when "Feb"
      newDate = date[8,12] + "-" + "02" + "-" + date[4,6]
    when "Mar"
      newDate = date[8,12] + "-" + "03" + "-" + date[4,6]
    when "Apr"
      newDate = date[8,12] + "-" + "04" + "-" + date[4,6]
    when "May"
      newDate = date[8,12] + "-" + "05" + "-" + date[4,6]
    when "Jun"
      newDate = date[8,12] + "-" + "06" + "-" + date[4,6]
    when "Jul"
      newDate = date[8,12] + "-" + "07" + "-" + date[4,6]
    when "Aug"
      newDate = date[8,12] + "-" + "08" + "-" + date[4,6]
    when "Sep"
      newDate = date[8,12] + "-" + "09" + "-" + date[4,6]
    when "Oct"
      newDate = date[8,12] + "-" + "10" + "-" + date[4,6]
    when "Nov"
      newDate = date[8,12] + "-" + "11" + "-" + date[4,6]
    when "Dec"
      newDate = date[8,12] + "-" + "12" + "-" + date[4,6]
    end
    return newDate
  end

end
