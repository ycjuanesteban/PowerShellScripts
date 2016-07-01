function Execute-Query{
    <#
    .SYNOPSIS
    Helper que permite Ejecutar una query en una base de datos
    .DESCRIPTION
    Helper que permite Ejecutar una query en una base de datos
    .PARAMETER SqlServer
    Nombre o ip del servidor
    .PARAMETER SqlDbName
    Nombre de la base de datos
    .PARAMETER SqlUser
    Nombre de usuario
    .PARAMETER SqlPass
    Clave del usuario
    .PARAMETER SqlQuery
    Consulta 
    .EXAMPLE
    Execute-Query -SqlServer NOMBRE_SERVIDOR -SqlDbName DBNAME -SqlUser USUARIO -SqlPass CLAVE -SqlQuery CONSULTA
    #>
    param(
    [Parameter(Mandatory=$True)][string]$SqlServer,
    [Parameter(Mandatory=$True)][string]$SqlDbName,
    [Parameter(Mandatory=$True)][string]$SqlUser,
    [Parameter(Mandatory=$True)][string]$SqlPass,
    [Parameter(Mandatory=$True)][string]$SqlQuery
    )

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $DataSet = New-Object System.Data.DataSet

    $SqlConnection.ConnectionString = "Server = $SqlServer; DataBase = $SqlDbName; Integrated Security = True; User = $SqlUser; Password = $SqlPass"
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter.SelectCommand = $SqlCmd
    $SqlAdapter.Fill($DataSet)

    $DataSet.Tables[0]
}