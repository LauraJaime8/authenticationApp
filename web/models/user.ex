defmodule SimpleAuth.User do
  use SimpleAuth.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :is_admin, :boolean, default: false
    has_many :posts, SimpleAuth.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(email)a #~w: devuelve una lista de palabras separada por comas
                              #a: las palabras de la lista son de tipo atom
  @optional_fields ~w(name is_admin)a

  #https://hexdocs.pm/ecto/Ecto.Changeset.html
  def changeset(struct, params \\ %{}) do
    struct
    # |> This operator introduces the expression on the left-hand side as the first argument to the function call on the right-hand side.
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  #Pasamos la estructura de cambios de nuestro usuario a través
  #del conjunto de cambios, luego seleccionamos el parametro contraseña,
  #validamos su longitud en invocamos la funcion hash_password
  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, ~w(password)a, [])
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  #Comprueba si el conjunto de cambios es valido y los cambios en la estructura
  #del usuario contienen: parametro de contraseña
  defp hash_password(changeset) do
    case changeset do
      #Comprueba que en el conjunto de cambios contiene la contraseña
      #que es modificada.
      #Si todo es correcto, devuelve la hash de la contraseña con la libreria comeonin
      #y si no devuelve el conjunto de cambios.
      %Ecto.Changeset{valid?: true,
                      changes: %{password: password}} ->
        put_change(changeset,
                  :password_hash,
                  Comeonin.Bcrypt.hashpwsalt(password))
        _ ->
          changeset
    end
  end
end
