using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LearningEnglish.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveRenderedHtmlFromLecture : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RenderedHtml",
                table: "Lectures");

            migrationBuilder.DropColumn(
                name: "DescriptionImage",
                table: "AssetsFrontend");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "AssetsFrontend");

            migrationBuilder.DropColumn(
                name: "Order",
                table: "AssetsFrontend");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                column: "PasswordHash",
                value: "$2a$11$gmXwlEH7Qpq7UTPSJ4T2yuBhBGgf6WurWzhZH7sZV7uFK0S3zHitW");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "RenderedHtml",
                table: "Lectures",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescriptionImage",
                table: "AssetsFrontend",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "AssetsFrontend",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Order",
                table: "AssetsFrontend",
                type: "integer",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                column: "PasswordHash",
                value: "$2a$11$Mh7ZmooC8XMr8LJj2HR7Ge7V2vRuOgwZbus56hFY3XuDMdz47Avaa");
        }
    }
}
