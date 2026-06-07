using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TaskHub.API.Migrations
{
    /// <inheritdoc />
    public partial class TareaContada : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Contada",
                table: "Tasks",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Contada",
                table: "Tasks");
        }
    }
}
